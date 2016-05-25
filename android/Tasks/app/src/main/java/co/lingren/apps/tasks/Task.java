package co.lingren.apps.tasks;

import com.google.firebase.database.Exclude;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

/**
 * Created by hlingren on 5/25/16.
 */
public class Task {
    public String title;
    public String notes;
    public String key;

    public Task() {
        title = "";
        notes = "";
        key = "";
    }

    public Task(String t, String n, String k) {
        title = t; notes = n; key = k;
    }

    @Exclude
    public Map<String, Object> toMap() {
        HashMap<String, Object> result = new HashMap<>();
        result.put("key",key);
        result.put("title",title);
        result.put("notes",notes);

        return result;
    }
}
