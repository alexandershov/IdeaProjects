# pandas is a library for working with the numerical tables and time series

# pd is a traditional shorthand for pandas
import pandas as pd
import io

CSV_FILEOBJ = io.StringIO('''name,age
sasa,38
andy,45
''')


def main():
    # series is a one-dimensional labeled array
    # you can pass labels via `index` argument
    series = pd.Series([1, 2, 3], index=['a', 'b', 'c'])
    # series behave like np.ndarray
    print(series + series)

    # data-frame is a labeled table (2d-array)
    # now we have a table with 3 rows and 2 columns ('first' and 'second')

    df = pd.DataFrame({'first': series, 'second': series + series})
    # there are many ways to create dataframes
    # dict[str, pd.Series] is not the only option

    # we can add new columns to dataframe
    df['new_column'] = series * 9

    # we can create dataframe from csv (we can also pass a filename)
    csv_df = pd.read_csv(CSV_FILEOBJ)

    # since Series and Dataframes behave like numpy array we can do
    # vectorized operations, this adds 1 to each value in the 'age' column
    csv_df['age'] += 1

    # create a dataframe with the first 2 rows
    csv_df.head(2)
    # create a dataframe with the last 2 rows
    csv_df.tail(2)

    # sort by second column
    csv_df.sort_index(axis=1)

    # select rows where 'first' value is > 2
    print(df[df['first'] > 2])

    # we can various dataframe stats
    print([df.mean(), df.median()])

    # we can concatenate dataframes (it will populate missing values with NaN
    pd.concat([df, csv_df])


if __name__ == '__main__':
    main()
