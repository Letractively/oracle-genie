package spencer.genie;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Stack;
import java.util.StringTokenizer;
import java.util.Vector;

import javax.servlet.http.HttpSessionBindingEvent;
import javax.servlet.http.HttpSessionBindingListener;

public class Connect implements HttpSessionBindingListener {

	private Connection conn = null;
	private String urlString = null;
	private String message = "";
	private List<String> tables;
	private Hashtable<String,String> comments;
	private Hashtable<String,String> constraints;
	private Hashtable<String,String> pkByTab;
	private Hashtable<String,String> pkByCon;
	private List<ForeignKey> foreignKeys;

	private List<String> schemas;
	private String schemaName;
	private String ipAddress;
	//private Hashtable<String, String> pkColumn;
	private HashMap<String, String> queryResult;
	private HashMap<String, QueryLog> queryLog;
	private HashMap<String, ArrayList<String>> pkMap;
	private Stack<String> history;
	
    public Connect(String url, String userName, String password, String ipAddress)
    {
    	//pkColumn = new Hashtable<String, String>();
    	queryResult = new HashMap<String, String>();
    	pkMap = new HashMap<String, ArrayList<String>>();
    	
    	history = new Stack<String>();
    	
    	this.ipAddress = ipAddress;
        try
        {
            Class.forName ("oracle.jdbc.driver.OracleDriver").newInstance ();
            conn = DriverManager.getConnection (url, userName, password);
            conn.setReadOnly(true);
            
            urlString = userName + "@" + url;  
            System.out.println ("Database connection established for " + urlString + " @" + (new Date()) + " " + ipAddress);
           
            	
            tables = new Vector<String>();
            comments = new Hashtable<String, String>();
            constraints = new Hashtable<String, String>();
            pkByTab = new Hashtable<String, String>();
            pkByCon = new Hashtable<String, String>();
            
            foreignKeys = new ArrayList<ForeignKey>();
            schemas = new Vector<String>();
            queryLog = new HashMap<String, QueryLog>();

//       		this.schemaName = conn.getCatalog();
       		this.schemaName = userName;
       		System.out.println("this.schemaName=" + this.schemaName);

            loadData();
        }
        catch (Exception e)
        {
            System.err.println ("3 Cannot connect to database server");
            message = e.getMessage();
        }
    }
    
    public boolean isConnected() {
    	return conn != null;
    }
    
    public void disconnect() {
    	if (conn != null)	{
    		try {
                conn.close ();
                System.out.println ("Database connection terminated for " + urlString + " @" + (new Date()) + " " + ipAddress);
            }
            	catch (Exception e) { /* ignore close errors */ }
        }
    	
    	conn = null;
    }
    
    public String getMessage() {
    	return message;
    }
    
    public Connection getConnection() {
    	return conn;
    }
    
    public List<String> getTables() {
    	return this.tables;
    }

    public String getTable(int idx) {
    	return (String) tables.get(idx);
    }
    
    public String getUrlString() {
    	return urlString;
    }

    public String getSchemaName() {
    	return this.schemaName;
    }
    
    public List<String> getSchemas() {
    	return this.schemas;
    }
    
    public String getSchema(int idx) {
    	return (String) schemas.get(idx);
    }
    
    public void getTableDetail(String table) throws SQLException {
    	DatabaseMetaData dbm = conn.getMetaData();
        ResultSet rs1 = dbm.getColumns(null,"%",table,"%");
        while (rs1.next()){
        	String col_name = rs1.getString("COLUMN_NAME");
        	String data_type = rs1.getString("TYPE_NAME");
        	int data_size = rs1.getInt("COLUMN_SIZE");
        	int nullable = rs1.getInt("NULLABLE");
/*        	
        	System.out.print(col_name+"\t"+data_type+"("+data_size+")"+"\t");
        	if(nullable == 1){
        		System.out.print("YES\t");
        	}
        	else{
        		System.out.print("NO\t");
        	}
        	System.out.println();
*/        	
        }
	}

    public void printQueryLog() {
    	HashMap<String, QueryLog> map = this.getQueryHistory();
    	
    	Iterator iterator = map.values().iterator();
    	int idx = 0;
    	while  (iterator.hasNext()) {
    		idx ++;
    		QueryLog ql = (QueryLog) iterator.next();
    		System.out.println(ql.getQueryString());
    	}
    	System.out.println("***] Query History from " + this.ipAddress);
    }
    
	public void valueBound(HttpSessionBindingEvent arg0) {
		// TODO Auto-generated method stub
		
	}

	public void valueUnbound(HttpSessionBindingEvent arg0) {
		printQueryLog();
		this.disconnect();
	}
	
	public void setSchema(String schema) throws SQLException {
		//conn.setCatalog(schema);
		//alter session set current_schema=BILL
		Statement stmt = conn.createStatement();
		stmt.execute("alter session set current_schema=" + schema);
		stmt.close();
		
		System.out.println("alter session set current_schema=" + schema);
		
		this.schemaName = schema;
		loadData();
	}

	private void loadData() {
		loadSchema();
		loadTables();
		loadComments();
		loadConstraints();
		loadPrimaryKeys();
		loadForeignKeys();
	}

	private void loadSchema() {
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select username from USER_USERS");	

       		while (rs.next()) {
       			String cat = rs.getString(1);
       			schemas.add(cat);
       			//System.out.println( "catalog: " + cat);       		
       		}
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("5 Cannot connect to database server");
             message = e.getMessage();
 		}
	}
		
	private void loadConstraints() {
		constraints.clear();
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, POSITION from user_cons_columns where position is not null order by 1,2,4");	

       		String prevConName = null;
       		String temp = "";
       		int counter = 0;
       		while (rs.next()) {
       			counter++;
       			String conName = rs.getString(1);
       			String tabName = rs.getString(2);
       			String colName = rs.getString(3);
       			int position = rs.getInt(4);
       			
       			if (position == 1) {
       				// process previous constraint
       				if (prevConName != null) {
       					//temp = temp + ")";
       					constraints.put(prevConName, temp);
       					//System.out.println(prevConName + "," + temp);
       					temp = "";
       				}
       				
       				temp = colName;
       				prevConName = conName;
       			} else {
       				temp += ", " + colName;
       			}
       		}
       		rs.close();
       		stmt.close();

       		//temp += ")";
			constraints.put(prevConName, temp);

		} catch (SQLException e) {
             System.err.println ("5 Cannot connect to database server");
             message = e.getMessage();
 		}
	}

	private void loadPrimaryKeys() {
		pkByTab.clear();
		pkByCon.clear();
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select * from user_constraints where CONSTRAINT_TYPE = 'P'");	

       		String prevConName = null;
       		String temp = "";
       		while (rs.next()) {
       			String conName = rs.getString("CONSTRAINT_NAME");
       			String tabName = rs.getString("TABLE_NAME");

       			pkByTab.put(tabName, conName);
       			pkByCon.put(conName, tabName);
       			//System.out.println(tabName + "," + conName);
       		}
       		rs.close();
       		stmt.close();

		} catch (SQLException e) {
             System.err.println ("6 Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
	}

	private void loadForeignKeys() {
		foreignKeys.clear();
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select * from user_constraints where CONSTRAINT_TYPE = 'R' order by table_name, constraint_type");	

       		while (rs.next()) {
       			ForeignKey fk = new ForeignKey();
       			fk.owner = rs.getString("OWNER");
       			fk.constraintName = rs.getString("CONSTRAINT_NAME");
       			fk.tableName = rs.getString("TABLE_NAME");
       			fk.rOwner = rs.getString("R_OWNER");
       			fk.rConstraintName = rs.getString("R_CONSTRAINT_NAME");
       			fk.deleteRule = rs.getString("DELETE_RULE");

       			foreignKeys.add(fk);
       		}
       		rs.close();
       		stmt.close();

		} catch (SQLException e) {
             System.err.println ("7 Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
	}

	private void loadComments() {
		comments.clear();

		// column comments
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select * from USER_COL_COMMENTS");	

	   		while (rs.next()) {
	   			String tab = rs.getString(1);
	   			String col = rs.getString(2);
	   			String comment = rs.getString(3);
	   			
	   			String key = tab + "." + col;
	   			if (comment != null && key != null) comments.put(key, comment);
	   			//System.out.println( key + ", " + comment);           		
	   		}
	   		rs.close();
	   		stmt.close();

		} catch (SQLException e) {
            System.err.println ("1 Cannot connect to database server");
            message = e.getMessage();
		}
		
		// table comments
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select * from USER_TAB_COMMENTS");	

	   		while (rs.next()) {
	   			String tab = rs.getString(1);
	   			//String type = rs.getString(2);
	   			String comment = rs.getString(3);
	   			
	   			if (comment != null && tab != null) comments.put(tab, comment);
	       		//System.out.println( tab + ", " + comment);       		
	   		}
	   		rs.close();
	   		stmt.close();

		} catch (SQLException e) {
            System.err.println ("2 Cannot connect to database server");
            message = e.getMessage();
		}

	}
	
	// get table comments
	public String getComment(String tname) {
		
		String key = tname.toUpperCase().trim();
		
		String comment = comments.get(key);
		return (comment != null? comment : "");
	}
	
	// get column comments
	public String getComment(String tname, String cname) {
		
		String key = (tname + "." + cname).toUpperCase().trim();
		
		String comment = comments.get(key);
		return (comment != null? comment : "");
	}
	
	public String getSynTableComment(String owner, String tname) {
		String res="";
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("SELECT COMMENTS FROM ALL_TAB_COMMENTS WHERE OWNER='" + owner +
       				"' AND TABLE_NAME='" + tname + "'");	

       		if (rs.next()) {
       			res = rs.getString("COMMENTS");
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("15 Cannot connect to database server");
             message = e.getMessage();
 		}
		
		if(res==null) res = "";
		return res;
		
	}
	
	public String getSynColumnComment(String owner, String tname, String cname) {
		String res="";
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("SELECT COMMENTS FROM ALL_COL_COMMENTS WHERE OWNER='" + owner +
       				"' AND TABLE_NAME='" + tname + "' AND COLUMN_NAME='" + cname + "'");	

       		if (rs.next()) {
       			res = rs.getString("COMMENTS");
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("16 Cannot connect to database server");
             message = e.getMessage();
 		}
		
		if(res==null) res = "";
		return res;
		
	}
	
	private void loadTables() {
		tables.clear();
		try {
			DatabaseMetaData dbm = conn.getMetaData();
			String[] types = {"TABLE"};
			ResultSet rs = dbm.getTables(null,schemaName.toUpperCase(),"%",types);
			//	System.out.println("Table name:");
			while (rs.next()){
				String tableSchema = rs.getString(2);
				String tableName = rs.getString("TABLE_NAME");
//				tables.add(tableSchema + "." + table);
				tables.add(tableName);
				
//		        // Get the table name
//		        String tableName = rs.getString(3);
//
//		        // Get the table's catalog and schema names (if any)
//		        String tableCatalog = rs.getString(1);
//		        String tableSchema = rs.getString(2);
//				tables.add(tableName + "|" + tableCatalog + "|" + tableSchema);
				
				//System.out.println(table);
			}
		} catch (SQLException e) {
            System.err.println ("4 Cannot connect to database server");
            message = e.getMessage();
		}
	}
	
	public String genie(String value, String tab, String targetCol, String sourceCol) {
		String res=null;
		
		String qry = "SELECT " + targetCol + " FROM " + tab + " WHERE " + sourceCol + "='" + value ;
		//System.out.println("genie: " +qry);
		
		try {
			Statement stmt = conn.createStatement();
			ResultSet rs = stmt.executeQuery(qry);
			
			if (rs.next()) {
				res = rs.getString(1);
			}
		
			rs.close();
			stmt.close();
		} catch (SQLException e) {
            System.err.println (e.toString());
		}
		
		return res;
	}
	
	public String genie(String srcCol, String tabCol) {
		String table = "";
		String targetCol = "";
		
		StringTokenizer st = new StringTokenizer(tabCol, "."); 
		table = st.nextToken();
		targetCol = st.nextToken();
	
		return genie(srcCol, table, targetCol, srcCol);
	}
	
	public String genie(String srcCol, String tabTargetCol, String tabSrcCol) {
		String table = "";
		String targetCol = "";
		
		StringTokenizer st = new StringTokenizer(tabTargetCol, "."); 
		table = st.nextToken();
		targetCol = st.nextToken();
	
		return genie(srcCol, table, targetCol, tabSrcCol);
	}
//	
//	public String getPrimaryKey(String catalog, String tname)  {
//		String colName = "";
//		
//		String key = catalog + "." + tname;
//		colName = (String) pkColumn.get(key);
//		if (colName != null) return colName;
//		
//		DatabaseMetaData dbm;
//		try {
//			dbm = conn.getMetaData();
//
//			// primary key
//			ResultSet rs = dbm.getPrimaryKeys(catalog, null, tname);
//			if (rs.next()){
//				colName = rs.getString("COLUMN_NAME");
//			}
//			rs.close();
//			
//			pkColumn.put(key, colName);
//			System.out.println("PK for " + catalog + "." + tname + " is " + colName);
//
//		} catch (SQLException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		}
//
//		return colName;
//	}

	public ArrayList<String> getPrimaryKeys(String catalog, String tname)  {
		ArrayList pk = null;
		String colName = "";
		
		String key = catalog + "." + tname;
		pk = pkMap.get(key);
		if (pk != null) return pk;
		
		DatabaseMetaData dbm;
		try {
			dbm = conn.getMetaData();

			// primary key
			pk = new ArrayList<String>();
			ResultSet rs = dbm.getPrimaryKeys(catalog, null, tname);
			while (rs.next()){
				colName = rs.getString("COLUMN_NAME");
				pk.add(colName);
			}
			rs.close();
			
			pkMap.put(key, pk);
			//System.out.println("PK for " + catalog + "." + tname + " is " + colName);

		} catch (SQLException e) {
			// TODO Auto-generated catch block
			//e.printStackTrace();
			return null;
		}

		return pk;
	}
	
	public String getQueryValue(String sql)  {
		String res = "";
		
		res = (String) queryResult.get(sql);
		if (res != null) return res;

		try {
			Statement stmt = conn.createStatement();
			ResultSet rs = stmt.executeQuery(sql);
			
			if (rs.next()) {
				res = rs.getString(1);
			}
			rs.close();
			stmt.close();
			
			if (res!= null)	queryResult.put(sql, res);
			//System.out.println(sql + " => " + res);
			
		} catch (SQLException e) {
			res = e.getMessage();
		}
		
		return res;
	}
	
	public ResultSet getQueryRS(String sql)  {
		ResultSet rs = null;
		
		try {
			Statement stmt = conn.createStatement();
			rs = stmt.executeQuery(sql);
			
			return rs;
		} catch (SQLException e) {
			rs = null;
		}
		
		return rs;
	}
	
	public void addQueryHistory(String qry) {
		QueryLog ql = new QueryLog(qry);
		queryLog.put(qry, ql);
	}
	
	public HashMap<String,QueryLog> getQueryHistory() {
		return queryLog;
	}
	
	public void ping() {
		String qry = "SELECT 1 from dual";
		try {
			Statement stmt = conn.createStatement();
			ResultSet rs = stmt.executeQuery(qry);
			
			rs.close();
			stmt.close();
		} catch (SQLException e) {
            System.err.println (e.toString());
		}
	}
	
	public String getPrimaryKeyName(String tname) {
		if (tname.contains(".")) {
			String[] temp = tname.split("\\.");
			return getPrimaryKeyName(temp[0], temp[1]);
		}
		
		String pkName = pkByTab.get(tname.toUpperCase());
		
		// check for Synonym
		if (pkName == null) {
			String syn=getSynonym(tname) ;
			if (syn != null && syn.contains(".")) {
				return getPrimaryKeyName(syn);
			}
		}		
		
		return pkName;
	}

	public String getPrimaryKeyName(String owner, String tname) {
		String qry = "SELECT CONSTRAINT_NAME FROM ALL_CONSTRAINTS WHERE OWNER='" +
				owner + "' AND TABLE_NAME='" + tname + "' AND CONSTRAINT_TYPE = 'P'";
		
		return queryOne(qry);
	}

	public String getTableNameByPrimaryKey(String kname) {
		String tName = pkByCon.get(kname.toUpperCase());
		
		// check for other owner
		if (tName == null) {
			String owner = this.queryOne("SELECT OWNER FROM ALL_CONSTRAINTS WHERE CONSTRAINT_NAME='" + kname +"'");
			return getTableNameByPrimaryKey(owner, kname);
		}
		
		return tName;
	}

	public String getTableNameByPrimaryKey(String owner, String kname) {
		if (owner==null) return this.getTableNameByPrimaryKey(kname);

		String qry = "SELECT OWNER||'.'||TABLE_NAME FROM ALL_CONSTRAINTS WHERE OWNER='" +
				owner + "' AND CONSTRAINT_NAME='" + kname + "'";
		return this.queryOne(qry);
	}

	public List<String> getConstraintColList(String cname) {
		if (cname.contains(".")) {
			String[] temp = cname.split("\\.");
			return getConstraintColList(temp[0], temp[1]);
		}
		
		
		// check for other owner
		String owner = this.queryOne("SELECT OWNER FROM ALL_CONSTRAINTS WHERE CONSTRAINT_NAME='" + cname +"'");
		if (owner != null) {
			return getConstraintColList(owner, cname);
		}
		
		return getConstraintColList(this.getSchemaName().toUpperCase(), cname);
	}

	public List<String> getConstraintColList(String owner, String cname) {
		if (owner == null) owner = this.getSchemaName().toUpperCase();
		
		List<String> list = new ArrayList<String>();
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select column_name from all_cons_columns where " +
       				"owner='" + owner + "' AND constraint_name='" + cname + "' order by position");	

       		while (rs.next()) {
       			String colName = rs.getString(1);
       			list.add(colName);
       		}
       		rs.close();
       		stmt.close();

		} catch (SQLException e) {
             System.err.println ("getConstraintColList - Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		return list;
	}

	public String getConstraintCols(String cname) {
		if (cname == null) return "";
		String cols = constraints.get(cname.toUpperCase());
		
		// check for other owner
		if (cols==null) {
			String owner = this.queryOne("SELECT OWNER FROM ALL_CONSTRAINTS WHERE CONSTRAINT_NAME='" + cname +"'");
			if (owner != null) {
				return getConstraintCols(owner, cname);
			}
		}
		
		if (cols==null) cols = "";
		return cols;
	}

	public String getConstraintCols(String owner, String cname) {
		
		if (owner == null) return getConstraintCols(cname);
		
		String res = "";
		String qry = "SELECT COLUMN_NAME from all_cons_columns where  CONSTRAINT_NAME='" + cname 
				+ "' and owner='" + owner + "' ORDER BY position";
		
		List<String> list = queryMulti(qry);

		for (int i=0; i<list.size(); i++) {
			if (i==0) res = list.get(i);
			else res +=", " + list.get(i);
		}
		
		return res;
	}

	public List<ForeignKey> getForeignKeys(String tname) {
		
		if (tname.contains(".")) {
			String[] temp = tname.split("\\.");
			return getForeignKeys(temp[0], temp[1]);
		}
		
		List list = new ArrayList<ForeignKey>();
		
		for (int i=0; i<foreignKeys.size(); i++) {
			ForeignKey fk = foreignKeys.get(i);
			if (fk.tableName.equals(tname)) {
				list.add(fk);
			}
		}
		
		
		// check for Synonym table
		if (list.size()==0) {
			String syn = getSynonym(tname);
			if (syn != null && syn.contains(".")) {
				return getForeignKeys(syn);
			}
		}
					
		return list;
	}

	public List<ForeignKey> getForeignKeys(String owner, String tname) {
		List<ForeignKey> list = new ArrayList<ForeignKey>();
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select * from all_constraints where CONSTRAINT_TYPE = 'R' " +
       				"AND owner='" + owner + "' AND table_name='" + tname + "' order by table_name, constraint_type");	

       		while (rs.next()) {
       			ForeignKey fk = new ForeignKey();
       			fk.owner = rs.getString("OWNER");
       			fk.constraintName = rs.getString("CONSTRAINT_NAME");
       			fk.tableName = rs.getString("TABLE_NAME");
       			fk.rOwner = rs.getString("R_OWNER");
       			fk.rConstraintName = rs.getString("R_CONSTRAINT_NAME");
       			fk.deleteRule = rs.getString("DELETE_RULE");

       			list.add(fk);
       		}
       		rs.close();
       		stmt.close();

		} catch (SQLException e) {
             System.err.println ("7 Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		return list;
	}

	public List<String> getReferencedTables(String tname) {
		
		if (tname.contains(".")) {
			String[] temp = tname.split("\\.");
			return getReferencedTables(temp[0], temp[1]);
		}
		
		List<String> list = new ArrayList<String>();

		String pkName = getPrimaryKeyName(tname);
		if (pkName == null) return list;
		
		for (int i=0; i<foreignKeys.size(); i++) {
			ForeignKey fk = foreignKeys.get(i);
			if (fk.rConstraintName.equals(pkName)) {
				list.add(fk.tableName);
			}
		}
		
		// check for synonym
		if (list.size()==0) {
			String syn = getSynonym(tname);
			if (syn != null && syn.contains(".")) {
				return getReferencedTables(syn);
			}
		}
		
		// sort by table name and remove dups.
		Set <String> set = new HashSet<String>(list);
		
		List<String> list2 = new ArrayList<String>(set);
		Collections.sort(list2);
		
		return list2;
	}

	public List<String> getReferencedTables(String owner, String tname) {
		if (owner == null) return getReferencedTables(tname);
		
		String pkName = getPrimaryKeyName(owner, tname);
		
		String qry = "SELECT OWNER||'.'||TABLE_NAME FROM ALL_CONSTRAINTS WHERE " +
				"R_CONSTRAINT_NAME='" + pkName +"' ORDER BY TABLE_NAME";
		
		return this.queryMulti(qry);
	}
	
	public List<String> getReferencedPackages(String tname) {
		List<String> list = new ArrayList<String>();

		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select distinct NAME from user_dependencies WHERE REFERENCED_NAME='" + tname + "' AND TYPE IN ('TYPE BODY','PACKAGE BODY','PACKAGE','TYPE','PROCEDURE','FUNCTION') ORDER BY NAME");	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String name = rs.getString("NAME");
       			list.add(name);
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("10 Cannot connect to database server");
             message = e.getMessage();
 		}
		
		return list;
	}
	
	public List<String> getReferencedViews(String tname) {
		List<String> list = new ArrayList<String>();

		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select distinct NAME from user_dependencies WHERE REFERENCED_NAME='" + tname + "' AND TYPE IN ('VIEW') ORDER BY NAME");	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String name = rs.getString("NAME");
       			list.add(name);
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("11 Cannot connect to database server");
             message = e.getMessage();
 		}
		
		return list;
	}
	
	public List<String> getIndexes(String owner, String tname) {
		List<String> list = new ArrayList<String>();

		if (owner == null) owner = this.getSchemaName().toUpperCase();
		try {
			Statement stmt = conn.createStatement();
			ResultSet rs = stmt.executeQuery("SELECT INDEX_NAME, UNIQUENESS FROM ALL_INDEXES WHERE OWNER='" + owner + "' AND TABLE_NAME='" + tname +"'");

			while (rs.next()) {
				String indexName = rs.getString(1);
				
				String t = getTableNameByPrimaryKey(indexName);
				if (t != null) continue; // skip if PK

				String unique = rs.getString(2);
				if (unique.equals("NONUNIQUE")) unique="";
       			list.add(indexName);
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("13 Cannot connect to database server");
             message = e.getMessage();
 		}
		
		return list;
	}
	
	public List<String> getReferencedTriggers(String tname) {
		List<String> list = new ArrayList<String>();

		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select distinct NAME from user_dependencies WHERE REFERENCED_NAME='" + tname + "' AND TYPE IN ('TRIGGER') ORDER BY NAME");	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String name = rs.getString("NAME");
       			list.add(name);
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("12 Cannot connect to database server");
             message = e.getMessage();
 		}
		
		return list;
	}
	
	public String getIndexColumns(String owner, String iname) {
		String res = "(";
		if (owner == null) owner = this.getSchemaName().toUpperCase();
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select * from ALL_IND_COLUMNS WHERE " +
       				"TABLE_OWNER='" + owner + "' AND INDEX_NAME='" + iname + "' ORDER BY COLUMN_POSITION");	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String cname = rs.getString("COLUMN_NAME");
       			if (count > 1) res +=", ";
       			res += cname;
       		}
       		
       		res +=")";
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("getIndexColumns - ");
             message = e.getMessage();
 		}
		
		return res;
	}
	
	public String getDependencyPackage(String owner, String name) {
		String res = "";
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select REFERENCED_OWNER, REFERENCED_NAME, REFERENCED_TYPE from all_dependencies WHERE OWNER='" + owner + "' AND NAME='" + name + "' AND REFERENCED_TYPE IN ('PACKAGE','FUNCTION','PROCEDURE','TYPE') ORDER BY REFERENCED_NAME");	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String rowner = rs.getString("REFERENCED_OWNER");
       			String rname = rs.getString("REFERENCED_NAME");
       			String rtype = rs.getString("REFERENCED_TYPE");
       			
       			if(!rowner.equalsIgnoreCase(this.getSchemaName()))
       				rname = rowner + "." + rname;
       			res += "<a href='javascript:loadPackage(\""+ rname + "\")'>" + rname + "</a>&nbsp;&nbsp;<br/>";
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("9 Cannot connect to database server");
             message = e.getMessage();
 		}
		
		return res;
	}

	public String getDependencyTable(String owner, String name) {
		String res = "";
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select REFERENCED_OWNER, REFERENCED_NAME, REFERENCED_TYPE from all_dependencies WHERE OWNER='" + owner + "' and NAME='" + name + "' AND REFERENCED_TYPE IN ('TABLE') ORDER BY REFERENCED_NAME");	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String rowner = rs.getString("REFERENCED_OWNER");
       			String rname = rs.getString("REFERENCED_NAME");
       			String rtype = rs.getString("REFERENCED_TYPE");
       			
       			if(!rowner.equalsIgnoreCase(this.getSchemaName()))
       				rname = rowner + "." + rname;

       			res += "<a href='javascript:loadTable(\""+ rname + "\")'>" + rname + "</a>&nbsp;&nbsp;<br/>";
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("10 Cannot connect to database server");
             message = e.getMessage();
 		}
		
		
		return res;
	}

	public String getDependencyView(String owner, String name) {
		String res = "";
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select REFERENCED_OWNER, REFERENCED_NAME, REFERENCED_TYPE from all_dependencies WHERE OWNER='" + owner + "' AND NAME='" + name + "' AND REFERENCED_TYPE IN ('VIEW') ORDER BY REFERENCED_NAME");	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String rowner = rs.getString("REFERENCED_OWNER");
       			String rname = rs.getString("REFERENCED_NAME");
       			String rtype = rs.getString("REFERENCED_TYPE");
       			
       			if(!rowner.equalsIgnoreCase(this.getSchemaName()))
       				rname = rowner + "." + rname;

       			res += "<a href='javascript:loadView(\""+ rname + "\")'>" + rname + "</a>&nbsp;&nbsp;<br/>";
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("getDependencyView - Cannot connect to database server");
             message = e.getMessage();
 		}
		
		
		return res;
	}

	public String getDependencySynonym(String owner, String name) {
		String res = "";
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select distinct REFERENCED_OWNER, REFERENCED_NAME, REFERENCED_TYPE from all_dependencies WHERE OWNER='" + owner + "' and NAME='" + name + "' AND REFERENCED_TYPE IN ('SYNONYM') ORDER BY REFERENCED_NAME");	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String rowner = rs.getString("REFERENCED_OWNER");
       			String rname = rs.getString("REFERENCED_NAME");
       			String rtype = rs.getString("REFERENCED_TYPE");
       			
       			if(!rowner.equalsIgnoreCase(this.getSchemaName()))
       				rname = rowner + "." + rname;

       			res += "<a href='javascript:loadSynonym(\""+ rname + "\")'>" + rname + "</a>&nbsp;&nbsp;<br/>";
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("getDependencySynonym - Cannot connect to database server");
             message = e.getMessage();
 		}
		
		return res;
	}

	public String queryOne(String qry) {
		String res = "";
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(qry);	

       		if (rs.next()) {
       			res = rs.getString(1);
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("queryOne - " + qry);
             message = e.getMessage();
 		}
		return res;
	}
	
	public List<String> queryMulti(String qry) {
		List <String> list = new ArrayList<String>();
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(qry);	

       		while (rs.next()) {
       			String res = rs.getString(1);
       			list.add(res);
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("queryMulti - " + qry);
             message = e.getMessage();
 		}
		return list;
	}

	public String getSynonym(String sname) {
		String qry = "SELECT table_owner||'.'||table_name FROM user_synonyms where synonym_name='" + sname + "'";
		return this.queryOne(qry);
	}
	
	public int getPKLinkCount(String tname, String cols, String keys) {
		int cnt = 0;
		
		String condition = Util.buildCondition(cols,  keys);
		String qry = "SELECT COUNT(*) FROM " + tname + " WHERE " + condition;

		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(qry);	

       		if (rs.next()) {
       			cnt = rs.getInt(1);
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("getPKLinkCount - " + qry);
             message = e.getMessage();
 		}
		
		return cnt;
	}

	public String getObjectType(String oname) {
		if (oname.contains(".")) {
			String[] temp = oname.split("\\.");
			return getObjectType(temp[0], temp[1]);
		}
		
		String qry = "SELECT OBJECT_TYPE FROM USER_OBJECTS WHERE OBJECT_NAME='" + oname + "'";
		return queryOne(qry);
	}

	public String getObjectType(String owner, String oname) {
		String qry = "SELECT OBJECT_TYPE FROM ALL_OBJECTS WHERE OWNER='" + owner + "' AND OBJECT_NAME='" + oname + "'";
		return queryOne(qry);
	}

}