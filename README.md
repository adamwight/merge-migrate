This database migration tool is meant for merging schemas that may or may not
have shared common history.  It has been used to collapse multi-site Drupal
installations, but the design is abstracted from schema specifics.

It works in several passes, analysis, planning and execution, allowing the
operator to examine intermediate results and make adjustments before the
migration is committed.

Database rows are compared by ID first, then by contents.  Results are
categorized into added, identical, and changed rows.

How to use
==========

Create .yaml files in the `config` directory, using any name, specifying at
least the following information about your migration:

    # One simple migration is to only make additions.  However, this will
    # fail if there are conflicts on the table's primary key.  In that
    # case, additional migrations should be performed on changed rows.
    # 
    # Each item in this list corresponds to a function in TableMigration,
    # called in the given order during the execute() phase.
    strategy:
        - make_additions
    
    # Leave this safety switch on until you are certain the migration is
    # configured correctly.
    nocommit: true
    
    # Here are the meat and potatoes.  Only tables named here will be operated
    # upon.  The mapped values are a spec for how the table should be migrated.
    tables:
        # ....
        # other tables
        # ....

        panels_pane:
            # For a primary multi-key, the syntax would be, key: [ pid, nid ]
            key: pid
            foreign_keys:
                # Listing foreign keys makes it possble to fix references
                # when panels_display rows are ID-shifted.
                did: panels_display.did
            include:
                # If you only want to merge certain rows, discarding the
                # others, list them like so.  Alternatively, you may use
                # the "exclude" key.
                - 37
                - 60
                - 62
                - 64
                - 65
            strategy:
                # Strategy can be overridden per table.
                - make_additions
                - shift_changes
