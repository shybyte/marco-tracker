pub const Adsr = struct {
    value: f32 = 0,

    const Self = @This();

    pub fn trigger(self: *@This()) void {
        self.value = 1.0;
    }

    pub fn generate(self: *@This()) f32 {
        if (self.value > 0) {
            self.value = self.value - 0.0001;
        }
        return self.value;
    }
};
