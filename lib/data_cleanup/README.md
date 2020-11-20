# DataCleanups

This module is used to clean database records that have become invalid since data validation rules have changed within the app.

## Rake tasks

This module adds two rake tasks, one for finding invalid records, and one for fixing them.

### Usage

Find invalid records.

#### Warning:

This will iterate over every record on your database. It could easily take over an hour to run.

``` bash
$ rake data_cleanup:find_invalid_records
```

Find invalid records for a given list of models.

``` bash
$ rake data_cleanup:find_invalid_records INCLUDE=Note,User
```

...or...

``` bash
$ rake data_cleanup:find_invalid_records EXCLUDE=Annotation
```

---

Fix invalid records based on the rules defined in `lib/data_cleanup/rules`.

#### Warning:

This will update the records on your database, often using `update_all`. Make sure you:

- **have a backup of your database**
- **you are comfortable you understand what each of these rules are doing to your data**

``` bash
$ rake data_cleanup:clean_invalid_records
```

Or to clean a given table...

``` bash
$ rake data_cleanup:clean_invalid_records INCLUDE=Question
```

To avoid a given table...

``` bash
$ rake data_cleanup:clean_invalid_records EXAMPLE=Plan
```

## Rules

Each type of data error is fixed separately.

These are defined in `lib/data_cleanup/rules`.

### Creating a new rule

You can create a new rule by running the following genrator:

``` bash
$ rails g data_cleanup_rule user/fix_missing_emails
```

This will create a file `lib/data_cleanup/rules/user/fix_missing_emails.rb` which contains the rules for updating users with missing emails.

Feel free to add your own rules where neccesary to fix your own data.

## Logging output

Output from the Rake tasks will be logged to `log/validations.log`.
