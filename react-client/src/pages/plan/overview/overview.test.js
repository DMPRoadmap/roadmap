import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import AddPlan from './add';

describe('Dashboard', () => {
  it('renders the title', () => {
    render(<AddPlan />);
    const add_text = screen.getByText("Add a Plan");
    expect(add_text).toBeInTheDocument()
  });
});
