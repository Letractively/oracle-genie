package spencer.genie;

public class DataDef  {
	String value;
	boolean isNull = false;

	public int compareTo(DataDef target, String typeName) {
		
		if (this.isNull) return -1;
		if (target.isNull) return 1;
		
		if (typeName.equals("NUMBER")) {
			double d1 = Double.valueOf(this.value);
			double d2 = Double.valueOf(target.value);
			
			if (d1 > d2)
				return 1;
			else
				return -1;
		}
		
		return this.value.compareTo(target.value);
	}
}
