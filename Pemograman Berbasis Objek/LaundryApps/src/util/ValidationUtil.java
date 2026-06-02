package util;

import Error.ValidationException;
import Model.User;

public class ValidationUtil {
	public static void validate(User user) throws ValidationException, NullPointerException{
		if(user.getUsername() == null) {
			throw new NullPointerException("Username is null");
		}else if(user.getUsername().isBlank()) {
			throw new NullPointerException("Username is empty");
		}else if(user.getPassword() == null) {
			throw new NullPointerException("Password is null");
		}else if(user.getPassword().isBlank()) {
			throw new NullPointerException("Password is empty");
		}
	}
}
