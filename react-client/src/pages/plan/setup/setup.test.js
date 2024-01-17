import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import PlanNew from './new.js';

describe('Dashboard', () => {
  it('renders the title', () => {
    render(<PlanNew />);
    const new_text = screen.getByText("New Plan");
    expect(new_text).toBeInTheDocument()
  });
});
